#!/bin/sh

# Check if we're already in tmux
if [ ! $TMUX ]
then
  # Make sure we have tmux installed
  if command -v tmux > /dev/null
  then
    # Check for existing tmux sessions
    if tmux ls &> /dev/null
    then
      tmux attach
    else
      sleep 1
      if [[  -z $WORK_MACHINE  ]]; then
        tmux new -c "/Users/${USER}/notes/main" -n "notes" nvim \;\
          send-keys -t 0 ",ww" \;\
          send-keys -t 0 ",aft" \;\
          new-window -c "/Users/${USER}/Projects" \;\
          select-window -l
      else
        tmux new -c "/Users/${USER}/notes/main" -n "notes" nvim \;\
          send-keys -t 0 ",w,w" \;\
          send-keys -t 0 ",aft" \;\
          new-window -c "/Users/${USER}/Projects" \;\
          select-window -l
      fi
    fi
  else
    echo "You don't have tmux installed : ("
  fi
fi

