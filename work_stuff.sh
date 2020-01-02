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
      tmux new -c "/Users/${USER}/work_notes" -n "notes" nvim \;\
        send-keys -t 0 "2,w,w" \;\
        send-keys -t 0 ",v" \;\
        send-keys -t 0 "2,ww" \;\
        send-keys -t 0 ",1" \;\
        new-window -c "/Users/${USER}/Projects" \;\
        select-window -l
    fi
  else
    echo "You don't have tmux installed : ("
  fi
fi

