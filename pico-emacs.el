;;; pico-emacs.el --- Tools for Raspberry Pi / Pico coding

;; 
;; SPDX-FileCopyrightText: Copyright (C) 2025 Thomas W. Rake
;;
;; SPDX-License-Identifier: GPL-3.0-or-later
;;



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

(defcustom openocd-interface "interface/cmsis-dap.cfg"
  "The interface string for openocd. This is the debugging interface."
  :type 'string
  :group 'pico-emacs)

(defcustom openocd-target "target/rp2350.cfg"
  "The target string for openocd. The is cpu chip.
   Should be target/rp2350.cfg or target/rp2040"
  :type 'string
  :group 'pico-emacs)

(defun pico-sentinel (process event)
   (princ
     (format "Process: %s had the event '%s'" process event)))

(defun kill-buffer-on-exit (process event)
  (when (string-equal "finished\n" event)
    (unless pico-keep-buffer-open 
      (kill-buffer (process-buffer process)))))

(defvar openocd-exec (concat (getenv "OPENOCD_DIR") "/" (getenv "OPENOCD_NAME"))
  "openocd to execute.")

(defvar pico-keep-buffer-open t "Don't kill the process buffer on job finish.")

(defun pico-start-openocd-server()
  "Start the openocd server"
  (interactive)
  (make-process :name "openocd-server"
		:command (list openocd-exec "-f" openocd-interface "-f" openocd-target)
		:buffer "*openocd-server*"
		:sentinel 'pico-sentinel)) 

(defun pico-stop-openocd-server ()
  "Stop the openocd server"
  (interactive)
  (delete-process "openocd-server"))
  
(defun is-alive-openocd-server()
  "Test if the openocd server is running."
  (process-live-p (get-process "openocd-server")))

(defun pico-upload-elf(elf)
  "Upload an elf file to the pico"
  (if (file-exists-p elf)
      (make-process :name "openocd-upload"
		    :command (list openocd-exec  "-f" openocd-interface "-f" openocd-target 
				     "-c" "adapter speed 5000" "-c" (concat "program " elf " verify reset exit"))
		    :buffer "*openocd-upload*"
		    :sentinel 'kill-buffer-on-exit)

    (format "file %s cannot be found." elf))) 


(defun pico-open-uart-terminal()
  "open a connection to the pico uart."
  (interactive)
  (vterm pico-uart)
  (find-buffer-visiting pico-uart)
  (seq-do
   #'(lambda (ch)
       (vterm-send-key (char-to-string ch)))
   pico-uart-connection-string))  


(defun pico-sentinel (process event)
   (princ
     (format "Process: %s had the event '%s'" process event)))

(defun kill-buffer-on-exit (process event)
  (when (string-equal "finished\n" event)
    (unless pico-keep-buffer-open 
      (kill-buffer (process-buffer process)))))



(provide 'pico-emacs)
