#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# VCS interface for git.

# Commits with a given message
# @param Message
function vcs_commit() {
    git commit -m "$*"
}

# Adds the given files to the next commit
# @param Files
function vcs_add() {
    git add $*
}

# Adds the given files to the next commit, interactively
# @param Files
function vcs_add_interactive() {
    git add --interactive $*
}

# Addes the given patterns to the ignore file
# @param Patterns to ignore
function vcs_ignore() {
    echo $* >> $vcs_src_path/.gitignore
}

# Outputs a diff
# @param Files
function vcs_diff() {
    git diff $*
}

# Return 0 if a branch exist
# @param Branch name
function vcs_branch_exists() {
    git branch | grep -q $*
    
    return $?
}

# Merge-squash source branch into a new target branch
# @param Source branch name
# @param Target branch name
function vcs_merge_squash() {
    local src_branch=${1:?Source branch not specified}
    local tgt_branch=${2:?Target branch not specified}
    git checkout master
    git fetch
    git pull origin master
    git checkout -b "$tgt_branch"
    git merge --squash "$src_branch"
    git commit -am "Merge/squash $src_branch into $tgt_branch"
    git push origin "$tgt_branch"
}
