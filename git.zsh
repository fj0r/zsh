alias g='git'
alias gs='git status'
alias gc='git checkout'
alias gci='git commit'
alias gca='git commit -a'
alias gcaa='git commit -a --amend'
alias gn='git checkout -b'
alias gb='git branch'
alias gbd='git branch -D'
alias gpl='git pull'
alias gps='git push'
function gpsu {
    local default='origin'
    eval $__default_indirect_object
    git push -u $y $z
}
alias gl='git log --oneline --decorate --graph'
alias glp='git log -p'
alias gly='git log --since=yesterday'
alias glt='git log --since=today'
alias glm='git log --since=midnight'
alias gm='git merge'
alias gr='git rebase -i --autosquash'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add .'
alias gut='git reset HEAD --'
alias grh='git reset --hard'
alias grhh='git reset --hard HEAD'
alias glst='git log -1 HEAD'
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'
function gtdr {
    local default='origin'
    eval $__default_indirect_object
    git push $y :refs/tags/$z
}
alias ggc='git reflog expire --all --expire=now && git gc --prune=now --aggressive'
function grad {
    local default='origin'
    eval $__default_indirect_object
    git remote add $y $z
}
function gcf  { vim .git/config }
