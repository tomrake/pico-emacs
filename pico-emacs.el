(defun pico-sentinel (process event)
   (princ
     (format "Process: %s had the event '%s'" process event)))

(defvar target-type (list "-f" "target/rp2350.cfg") "openocd target")

(defvar interface-type (list "-f" "interface/cmsis-dap.cfg") "openocd interface")

(defvar openocd-exec (concat (getenv "OPENOCD_DIR") "/" (getenv "OPENOCD_NAME"))
  "openocd to execute.")

(defun start-openocd-server()
  "Start the openocd server"
  (make-process :name "openocd-server"
		:command (append (list openocd-exec) interface-type target-type)
		:buffer "*openocd-server*"
		:sentinel 'pico-sentinel)) 

(defun stop-openocd-server ()
  "Stop the openocd server"
  (delete-process "openocd-server"))
  
(defun is-alive-openocd-server()
  "Test if the openocd server is running."
  (process-live-p (get-process "openocd-server")))
