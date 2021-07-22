(require 'json)
(require 'subr-x)
(require 'url)

(require 'f)
(require 's)
(require 'dash)
(require 'simple-httpd)

(require 'org)

(require 'ox)
(require 'ox-html)

(require 'org-roam)
(require 'org-roam-graph)

;;; Code:

(defvar org-roam-server-data nil)

(defvar org-roam-server-current-buffer (window-buffer))

(defvar org-roam-server-root
  (concat (file-name-directory
           (f-full (or
                    load-file-name
                    buffer-file-name)))
          "."))

(defvar org-roam-server-db-last-modification
  (float-time
   (file-attribute-modification-time
    (file-attributes org-roam-db-location))))

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

(defun org-roam-all-node-list ()
  "Return all nodes stored in the database as a list of key-value objects"
  (let ((rows (org-roam-db-query
               "SELECT
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
  atime,
  mtime,
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
    atime,
    mtime,
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
      files.atime as atime,
      files.mtime as mtime,
      tags.tag as tags,
      aliases.alias as aliases,
      '(' || group_concat(RTRIM (refs.\"type\", '\"') || ':' || LTRIM(refs.ref, '\"'), ' ') || ')' as refs
    FROM nodes
    LEFT JOIN files ON files.file = nodes.file
    LEFT JOIN tags ON tags.node_id = nodes.id
    LEFT JOIN aliases ON aliases.node_id = nodes.id
    LEFT JOIN refs ON refs.node_id = nodes.id
    GROUP BY nodes.id, tags.tag, aliases.alias )
  GROUP BY id, tags )
GROUP BY id")))
    (cl-loop for row in rows
             append (pcase-let* ((`(,id ,file ,level ,todo ,pos ,priority ,scheduled ,deadline
                                        ,title ,properties ,olp ,atime ,mtime ,tags ,aliases ,refs)
                                  row)
                                 (all-titles (cons title aliases)))
                      (mapcar (lambda (temp-title)
                                  (list (cons 'id id)
                                        (cons 'file file)
                                        (cons 'fileAtime (car (time-convert atime 1000)))
                                        (cons 'fileMtime (car (time-convert mtime 1000)))
                                        (cons 'level level)
                                        (cons 'point pos)
                                        (cons 'todo todo)
                                        (cons 'priority priority)
                                        (cons 'scheduled scheduled)
                                        (cons 'deadline deadline)
                                        (cons 'label temp-title)
                                        (cons 'properties properties)
                                        (cons 'olp olp)
                                        (cons 'tags tags)
                                        (cons 'refs refs)))
                              all-titles)))))

(defun org-roam-gather-options ()
  (list (cons 'autoGroup org-roam-network-auto-group))
  )

(defservlet* roam-data application/json ()
  (let ((data (json-encode (list (cons 'nodes (org-roam-all-node-list)) (cons 'edges (org-roam-all-link-list))))))
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

(provide 'org-roam-server)

;;; org-roam-server.el ends here
