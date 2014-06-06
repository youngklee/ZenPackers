Installing a VIM IDE setup with Synstastic
============================================
See
http://sontek.net/blog/detail/turning-vim-into-a-modern-python-ide#file-browser
as a base reference. We've changed up some of the packages that follow
for a more modern environment.

You want to do the following:

#. Copy your old .vimrc (and .vim if you have on) to a backup
#. Make some folders and init git::

   [zenoss@~]:  mkdir -p ~/.vim/{autoload,bundle}
   [zenoss@~]:  cd ~/.vim/
   [zenoss@.vim]:  git init

#. Install Pathogen::

   curl -Sso ~/.vim/autoload/pathogen.vim \
       https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

#. Paste the following into your .vimrc::
   execute pathogen#infect() 
   syntax on
   filetype plugin indent on

#. Now execute the following inside the .vim folder
   
::

   git submodule add http://github.com/tpope/vim-fugitive.git bundle/fugitive
   git submodule add https://github.com/msanders/snipmate.vim.git bundle/snipmate
   git submodule add https://github.com/tpope/vim-surround.git bundle/surround
   git submodule add https://github.com/tpope/vim-git.git bundle/git
   git submodule add https://github.com/ervandew/supertab.git bundle/supertab
   git submodule add https://github.com/sontek/minibufexpl.vim.git bundle/minibufexpl
   git submodule add https://github.com/wincent/Command-T.git bundle/command-t
   git submodule add https://github.com/mitechie/pyflakes-pathogen.git
   git submodule add https://github.com/mileszs/ack.vim.git bundle/ack
   git submodule add https://github.com/sjl/gundo.vim.git bundle/gundo
   git submodule add https://github.com/fs111/pydoc.vim.git bundle/pydoc
   git submodule add https://github.com/scrooloose/syntastic.git bundle/systastic
   git submodule add https://github.com/alfredodeza/pytest.vim.git bundle/py.test
   git submodule add https://github.com/reinh/vim-makegreen bundle/makegreen
   git submodule add https://github.com/vim-scripts/TaskList.vim.git bundle/tasklist
   git submodule add https://github.com/vim-scripts/The-NERD-tree.git bundle/nerdtree
   git submodule add https://github.com/sontek/rope-vim.git bundle/ropevim
   git submodule init
   git submodule update
   git submodule foreach git submodule init
   git submodule foreach git submodule update
