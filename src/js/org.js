export const openRoamProtocol = (nodeId) => {
    if (!nodeId) {
        return
    }
    let url = `org-protocol://roam-node?node=${nodeId}`
    window.open(url, "_self")
}
