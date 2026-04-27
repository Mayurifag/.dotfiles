#!/bin/sh
# AltTab preferences
# Edit this file to update settings — chezmoi apply will re-run on change

set -eu

defaults write com.lwouis.alt-tab-macos alignThumbnails -int 1
defaults write com.lwouis.alt-tab-macos appearanceSize -int 0
defaults write com.lwouis.alt-tab-macos appearanceStyle -int 0
defaults write com.lwouis.alt-tab-macos appsToShow -int 0
defaults write com.lwouis.alt-tab-macos crashPolicy -int 0
defaults write com.lwouis.alt-tab-macos cursorFollowFocus -int 0
defaults write com.lwouis.alt-tab-macos cursorFollowFocusEnabled -bool false
defaults write com.lwouis.alt-tab-macos fadeOutAnimation -bool true
defaults write com.lwouis.alt-tab-macos fontHeight -int 15
defaults write com.lwouis.alt-tab-macos hideAppBadges -bool false
defaults write com.lwouis.alt-tab-macos hideColoredCircles -bool true
defaults write com.lwouis.alt-tab-macos hideSpaceNumberLabels -bool true
defaults write com.lwouis.alt-tab-macos hideStatusIcons -bool false
defaults write com.lwouis.alt-tab-macos hideThumbnails -bool true
defaults write com.lwouis.alt-tab-macos hideWindowlessApps -bool true
defaults write com.lwouis.alt-tab-macos iconSize -int 20
defaults write com.lwouis.alt-tab-macos maxWidthOnScreen -int 79
defaults write com.lwouis.alt-tab-macos menubarIcon -int 1
defaults write com.lwouis.alt-tab-macos previewFocusedWindow -bool false
defaults write com.lwouis.alt-tab-macos screensToShow -int 0
defaults write com.lwouis.alt-tab-macos showFullscreenWindows -int 0
defaults write com.lwouis.alt-tab-macos showHiddenWindows -int 1
defaults write com.lwouis.alt-tab-macos showMinimizedWindows -int 1
defaults write com.lwouis.alt-tab-macos showOnScreen -int 1
defaults write com.lwouis.alt-tab-macos showTabsAsWindows -bool false
defaults write com.lwouis.alt-tab-macos showWindowlessApps -int 1
defaults write com.lwouis.alt-tab-macos showWindowlessApps3 -int 1
defaults write com.lwouis.alt-tab-macos showWindowlessApps4 -int 1
defaults write com.lwouis.alt-tab-macos spacesToShow -int 0
defaults write com.lwouis.alt-tab-macos theme -int 0
defaults write com.lwouis.alt-tab-macos titleTruncation -int 1
defaults write com.lwouis.alt-tab-macos updatePolicy -int 2
defaults write com.lwouis.alt-tab-macos windowDisplayDelay -int 0
defaults write com.lwouis.alt-tab-macos windowMaxWidthInRow -int 30
defaults write com.lwouis.alt-tab-macos windowMinWidthInRow -int 15
