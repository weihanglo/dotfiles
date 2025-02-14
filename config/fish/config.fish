# Default shell to fish
set -gx SHELL (command -v fish)

# A ninja in starship!
if test $fish_private_mode
  set -x __PRIVATE_MODE 🥷
else
  set -e __PRIVATE_MODE
end
