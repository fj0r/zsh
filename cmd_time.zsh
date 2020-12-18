zmodload zsh/datetime

_command_time_preexec() {
  timer=${timer:-${$(($EPOCHREALTIME*1000))%.*}}
  ZSH_COMMAND_TIME_MSG=${ZSH_COMMAND_TIME_MSG-"Time: %s"}
  ZSH_COMMAND_TIME_COLOR=${ZSH_COMMAND_TIME_COLOR-"white"}
  export ZSH_COMMAND_TIME=""
}

_command_time_precmd() {
  if [ $timer ]; then
    timer_show=$((${$(($EPOCHREALTIME*1000))%.*} - $timer))
    if [ -n "$TTY" ] && [ $timer_show -ge ${ZSH_COMMAND_TIME_MIN_SECONDS:-3000} ] || [ -n "$timing" ]; then
      export ZSH_COMMAND_TIME="$timer_show"
      if [ ! -z ${ZSH_COMMAND_TIME_MSG} ]; then
        zsh_command_time
      fi
    fi
    unset timer
  fi
}

_dot_color="66;66;66"
get_dot () {
  local STR=$@
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=" %{\x1b[38;2;${_dot_color}m%}"
  (( LENGTH = ${COLUMNS} - $LENGTH))

  for i in {0..$(($LENGTH - 11))}
    do
      SPACES="$SPACES."
    done
  SPACES="$SPACES%{$reset_color%} "

  echo $SPACES
}

zsh_command_time() {
    if [ -n "$ZSH_COMMAND_TIME" ]; then
        hours=$(($ZSH_COMMAND_TIME/3600000))
        min=$(($ZSH_COMMAND_TIME/60000%60))
        sec=$(($ZSH_COMMAND_TIME/1000%60))
        ms=$(($ZSH_COMMAND_TIME%1000))
        if [ "$ZSH_COMMAND_TIME" -le 1000 ]; then
            timer_show="$fg[green]$ms ms."
        elif [ "$ZSH_COMMAND_TIME" -gt 1000 ] && [ "$ZSH_COMMAND_TIME" -le 60000 ]; then
            timer_show="$fg[green]$sec s. $ms ms."
        elif [ "$ZSH_COMMAND_TIME" -gt 60000 ] && [ "$ZSH_COMMAND_TIME" -le 180000 ]; then
            timer_show="$fg[yellow]$min min. $sec s. $ms ms."
        else
            if [ "$hours" -gt 0 ]; then
                min=$(($min%60000))
                timer_show="$fg[red]$hours h. $min min. $sec s."
            else
                timer_show="$fg[red]$min min. $sec s."
            fi
        fi
        x="%{\x1b[38;2;${_dot_color}m%}..........%{$reset_color%}"
        print -rP "$(echo $x) ${ZSH_COMMAND_TIME_MSG} $timer_show $(get_dot ${ZSH_COMMAND_TIME_MSG} "$timer_show")"
    fi
}

precmd_functions+=(_command_time_precmd)
preexec_functions+=(_command_time_preexec)
