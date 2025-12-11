(defgroup pico-emacs
  nil "Configuration of pico development in emacs."
  :prefix "pico-"
  :group 'Programming)

(defcustom pico-uart "*pico-uart*"
  "The buffer name for the pico uart connection."
  :type 'string
  :group 'pico-emacs)

(defcustom pico-uart-connection-string "minicom -b 115200 -o -D /dev/ttyACM0\n"
  "The command to connect to pico uart."
  :type 'string
  :group 'pico-emacs)


(defun pico-sentinel (process event)
   (princ
     (format "Process: %s had the event '%s'" process event)))

(defun kill-buffer-on-exit (process event)
  (when (string-equal "finished\n" event)
    (unless keep-buffer-on-exit 
      (kill-buffer (process-buffer process)))))
(defvar keep-buffer-on-exit t "Don't kill the process buffer on job finish.")

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

(defun upload-elf(elf)
  "Upload an elf file to the pico"
  (if (file-exists-p elf)
      (make-process :name "openocd-upload"
		    :command (append (list openocd-exec) interface-type target-type
				     (list "-c" "adapter speed 5000" "-c" (concat "program " elf " verify reset exit")))
		    :buffer "*openocd-upload*"
		    :sentinel 'kill-buffer-on-exit)

    (format "file %s cannot be found." elf))) 


(defun open-pico-uart-terminal()
  "open a connection to the pico uart."
  (interactive)
  (vterm pico-uart)
  (find-buffer-visiting pico-uart)
  (seq-do
   #'(lambda (ch)
       (vterm-send-key (char-to-string ch)))
   pico-uart-connection-string))  
(defcustom pico-uart "*pico-uart*"
  "The buffer name for the pico uart connection."
  :type 'string
  :group 'pico-emacs)

(defcustom pico-uart-connection-string "minicom -b 115200 -o -D /dev/ttyACM0\n"
  "The command to connect to pico uart."
  :type 'string
  :group 'pico-emacs)


(defun pico-sentinel (process event)
   (princ
     (format "Process: %s had the event '%s'" process event)))

(defun kill-buffer-on-exit (process event)
  (when (string-equal "finished\n" event)
    (unless keep-buffer-on-exit 
      (kill-buffer (process-buffer process)))))
(defvar keep-buffer-on-exit t "Don't kill the process buffer on job finish.")

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

(defun upload-elf(elf)
  "Upload an elf file to the pico"
  (if (file-exists-p elf)
      (make-process :name "openocd-upload"
		    :command (append (list openocd-exec) interface-type target-type
				     (list "-c" "adapter speed 5000" "-c" (concat "program " elf " verify reset exit")))
		    :buffer "*openocd-upload*"
		    :sentinel 'kill-buffer-on-exit)

    (format "file %s cannot be found." elf))) 


(defun open-pico-uart-terminal()
  "open a connection to the pico uart."
  (interactive)
  (vterm pico-uart)
  (find-buffer-visiting pico-uart)
  (seq-do
   #'(lambda (ch)
       (vterm-send-key (char-to-string ch)))
   pico-uart-connection-string))  
