I suggest you create a fork of this, so you can modify it.

The approach used here is from https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/

To set this up on your machine, use this script: https://github.com/fastai/fastsetup/blob/master/dotfiles.sh

In that script, change `https://github.com/fastai/dotfiles.git` to your fork, before you run it.


TMUX config
Press Ctrl-b then type :source-file ~/.config/tmux/tmux.conf and hit Enter.
