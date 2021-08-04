(require 'json)
(require 'subr-x)
(require 'url)

(require 'f)
(require 's)
(require 'dash)
(require 'simple-httpd)

(require 'ox)
(require 'ox-html)

(require 'org-roam)

;;; Code:

(defvar org-roam-server-data nil)

(defvar org-roam-server-current-buffer (window-buffer))

(defvar org-roam-server-root
  (concat (file-name-directory
           (f-full (or
                    load-file-name
                    buffer-file-name)))
          "."))

(defgroup org-roam-server nil
  "org-roam-server customizable variables."
  :group 'org-roam)

(defcustom org-roam-server-host "127.0.0.1"
  "Server host.
http://`org-roam-server-host`:`org-roam-server-port`."
  :group 'org-roam-server
  :type 'string)

(defcustom org-roam-network-auto-group t
  "auto group nodes by edge"
  :group 'org-roam-server
  :type 'boolean)

(defcustom org-roam-network-label-wrap-length 15
  "node label wrap length"
  :group 'org-roam-server
  :type 'integer)

(defcustom org-roam-network-vis-options "{}"
  "node label wrap length"
  :group 'org-roam-server
  :type 'string)

(defcustom org-roam-server-port 8080
  "Server port.
http://127.0.0.1:`org-roam-server-port`."
  :group 'org-roam-server
  :type 'integer)

;;;###autoload
(define-minor-mode org-roam-server-mode
  "Start the http server and serve org-roam files."
  :lighter ""
  :global t
  :group 'org-roam-server
  :init-value nil
  (cond
   (org-roam-server-mode
    (setq-local httpd-port org-roam-server-port)
    (setq-local httpd-host org-roam-server-host)
    (setq httpd-root org-roam-server-root)
    (httpd-start))
   (t
    (httpd-stop))))

(defun org-roam-all-link-list ()
  "Return all links stored in the database as a list of key value objects"
  (let ((rows (org-roam-db-query
     "SELECT * FROM links where \"type\" ='\"id\"'")))
    (cl-loop for row in rows
             collect (pcase-let* ((`(,pos ,source ,dest ,type ,properties)
                                  row))
                              (list (cons 'pos pos)
                                    (cons 'from source)
                                    (cons 'to dest)
                                    (cons 'type type)
                                    (cons 'properties properties))))))

(defun org-roam-all-node-list (files)
  "Return all nodes stored in the database as a list of key-value objects"
  (let ((rows (org-roam-db-query
               (format "SELECT
  id,
  file,
  \"level\",
  todo,
  pos,
  priority ,
  scheduled ,
  deadline ,
  title,
  properties ,
  olp,
  createdTime,
  atime,
  modifiedTime,
  '(' || group_concat(tags, ' ') || ')' as tags,
  aliases,
  refs
FROM
  (
  SELECT
    id,
    file,
    \"level\",
    todo,
    pos,
    priority ,
    scheduled ,
    deadline ,
    title,
    properties ,
    olp,
    createdTime,
    atime,
    modifiedTime,
    tags,
    '(' || group_concat(aliases, ' ') || ')' as aliases,
    refs
  FROM
    (
    SELECT
      nodes.id as id,
      nodes.file as file,
      nodes.\"level\" as \"level\",
      nodes.todo as todo,
      nodes.pos as pos,
      nodes.priority as priority,
      nodes.scheduled as scheduled,
      nodes.deadline as deadline,
      nodes.title as title,
      nodes.properties as properties,
      nodes.olp as olp,
      nodes.createdTime as createdTime,
      files.atime as atime,
      files.modifiedTime as modifiedTime,
      tags.tag as tags,
      aliases.alias as aliases,
      '(' || group_concat(RTRIM (refs.\"type\", '\"') || ':' || LTRIM(refs.ref, '\"'), ' ') || ')' as refs
    FROM nodes 
    LEFT JOIN files ON files.file = nodes.file
    LEFT JOIN tags ON tags.node_id = nodes.id
    LEFT JOIN aliases ON aliases.node_id = nodes.id
    LEFT JOIN refs ON refs.node_id = nodes.id %s
    GROUP BY nodes.id, tags.tag, aliases.alias)
  GROUP BY id, tags)
GROUP BY id" (if (> (length files) 0)
                 (format " where nodes.file in (%s) " (mapconcat (lambda (x) (format "'%S'" x)) files ","))
                 "")))))
    (cl-loop for row in rows
             collect (pcase-let* ((`(,id ,file ,level ,todo ,pos ,priority ,scheduled ,deadline
                                        ,title ,properties ,olp ,createdTime ,atime ,modifiedTime ,tags ,aliases ,refs)
                                  row))
                          (list (cons 'id id)
                                (cons 'file file)
                                (cons 'fileAccessedTime (time-millis atime))
                                (cons 'fileModifiedTime modifiedTime)
                                (cons 'level level)
                                (cons 'point pos)
                                (cons 'todo todo)
                                (cons 'priority priority)
                                (cons 'scheduled scheduled)
                                (cons 'deadline deadline)
                                (cons 'title title)
                                (cons 'aliases aliases)
                                (cons 'properties properties)
                                (cons 'olp olp)
                                (cons 'createdTime createdTime)
                                (cons 'tags tags)
                                (cons 'refs refs))))))

(defun org-roam-gather-options ()
  "return options"
  (list (cons 'autoGroup org-roam-network-auto-group)
        (cons 'labelWrapLength org-roam-network-label-wrap-length)
        (cons 'visNetworkOptions org-roam-network-vis-options)
        )
  )

(defun org-roam-recent-node-changes (modifiedTime)
  "nodes in files that modified time after mtime"
  (let ((modifiedFiles (mapcar #'car (org-roam-db-query [:select file :from files
                                          :where (> modifiedTime $s1)] modifiedTime))))
    (if (= (length modifiedFiles) 0)
      '()
      (org-roam-all-node-list modifiedFiles))))

(defun org-roam-node-links (nodes)
  "根据 nodes，获取 nodes 所有的相关的 links
   nodes: list类型，元素为 node 对象
   return: nodes的所有相关的 link"
  (let* ((nodeIds (vconcat (mapcar #'cdar nodes)))
         (rows (org-roam-db-query [:select * :from links
                                          :where (and (in source $v1) (= type "id")) ] nodeIds)))
    (cl-loop for row in rows
             collect (pcase-let* ((`(,pos ,source ,dest ,type ,properties)
                                  row))
                              (list (cons 'pos pos)
                                    (cons 'from source)
                                    (cons 'to dest)
                                    (cons 'type type)
                                    (cons 'properties properties))))))

(defun time-millis (time-list)
  (car (time-convert time-list 1000)))

(defun time-list (milli-number)
  (time-convert (cons milli-number 1000) 'list))

(defun org-roam-file-max-mtime ()
  "return max file mtime"
    (caar (org-roam-db-query "select max(modifiedTime) from files")))

(defun org-roam-file-count ()
  "return file count"
   (caar (org-roam-db-query [:select (funcall count id) :from nodes])))

(defservlet* roam-data application/json ()
  (let ((data (json-encode (list (cons 'nodes (org-roam-all-node-list '())) (cons 'edges (org-roam-all-link-list))))))
    (insert (format "%s" data))))

(defservlet* roam-node application/json ()
  (let ((data (json-encode (org-roam-all-node-list))))
    (insert (format "%s" data))))

(defservlet* roam-link application/json ()
  (let ((data (json-encode (org-roam-all-link-list))))
    (insert (format "%s" data))))

(defservlet* roam-network-options application/json ()
  (let ((data (json-encode (org-roam-gather-options))))
    (insert (format "%s" data))))

(defservlet* roam-recent-changes application/json (version)
  (let ((changed-nodes (org-roam-recent-node-changes (string-to-number version))))
    (insert (json-encode (list (cons 'nodes changed-nodes) (cons 'links (org-roam-node-links changed-nodes)))))))

(defservlet* debugs text/plain ()
  (let ((rows (org-roam-db-query [:select [file mtime] :from files
                              :where (and (is-not mtime nil) (is modifiedTime nil))])))

    (insert (format "%s" (org-roam-file-max-mtime)))))

(defservlet* roam-get-file-changes application/json ()
    (insert (json-encode (list (cons 'mtime (org-roam-file-max-mtime)) (cons 'fileNumber (org-roam-file-count))))))

(provide 'org-roam-server)

;;; org-roam-server.el ends here
