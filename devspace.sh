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
      tmux new -c "/Users/${USER}/notes" -n "notes" nvim \;\
        send-keys -t 0 ",w,w" \;\
        send-keys -t 0 ",aft" \;\
        new-window -d -c "/Users/${USER}/Projects"
    fi
  else
    echo "You don't have tmux installed : ("
  fi
fi

