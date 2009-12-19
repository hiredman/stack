#!/bin/sh
CONS=0
nil=nil
false=nil
true=true
log=""
cons(){
  [ ! -z $log ] && echo "cons:" $1 $2 $3
  local name="CONS_"$CONS
  eval $name"_car="\$1
  eval $name"_cdr="\$2
  eval $3="$name"
  CONS=$(( $CONS + 1 ))
}

car(){
  [ ! -z $log ] && echo "car:" $1 $2 
  local name="$"$1"_car"
  local x=`eval echo $name`
  eval $2=$x
}

cdr(){
  [ ! -z $log ] && echo "cdr:" $1 $2
  local name="$"$1"_cdr"
  local x=`eval echo $name`
  eval $2=$x
}
string_cons(){
  local a
  local b
  local c
  car $1 a
  string $a a
  cdr $1 b
  string $b b
  c="($a $b)"
  eval $2="\"$c\""
}
string(){
  #echo "string:" $1 $2
  local r=`expr "$1" : "CONS_"`
  if [ $r -gt 0 ]; then
    string_cons $1 f
    eval $2=\"$f\"
  else
    eval $2=$1
  fi
}

combinator_dup=$true
combinator_dup(){
  local r1 r2 r3
  car $1 r20
  r1=$r20
  cons $r1 $1 r20
  eval $2=$r20
}

combinator_do=$true
combinator_do(){
  [ ! -z $log ] && echo "do:" $1 $2
  local r1 r2 r3 r4 r5 r6 r7 r8
  cdr $1 r20
  r1=$r20
  car $1 r20
  r2=$r20
  while true; do
    [ $r2 = $nil ] && break
    car $r2 r20
    push "$r20" $r1 r20
    r1=$r20
    cdr $r2 r20
    r2=$r20
  done
  eval $2=$r1
}

combinator_dumpstack=$true
combinator_dumpstack(){
  string $1 r20
  echo $r20
  eval $2=$1
}
combinator_dumpstack1=$true
combinator_dumpstack1(){
  string $STACK1 r20
  echo $r20
  eval $2=$1
}
combinator_def=$true
combinator_def(){
  local r1 r2 r3 r4 r5 r6 r7 r8
  car $1 r20
  cdr $1 r21
  car $r21 r2
  r1=$r20
  name="combinator_"$r2"=\$true"
  block="combinator_"$r2"_block=$r1"
  eval $name
  eval $block
  cdr $1 r20
  cdr $r20 r20
  eval $2=$r20
}

combinator_pair=$true
combinator_pair(){
  local r1 r2 r3
  car $1 r20
  cdr $1 r21
  car $r21 r21
  cdr $1 r22
  cdr $r22 r22
  r1=$r20
  r2=$r21
  r3=$r22
  cons $r2 $r1 r20
  cons $r20 $r3 r20
  eval $2=$r20
}

combinator_p=$true
combinator_p(){
  car $1 r20
  string $r20 r20
  echo $r20
  eval $2=$1
}

combinator_drop=$true
combinator_drop(){
  cdr $1 $2
}

combinator_pop=$true
combinator_pop(){
    local r1 r2 r3 r4 r5
    car $1 r20
    r1=$r20
    cdr $1 r20
    r2=$r20
    car $r1 r20
    cdr $r1 r21
    push $r20 $r2 r20
    push $r21 $r20 r20
    eval $2=$r20
}
combinator_if=$true
combinator_if(){
  [ ! -z $log ] && echo "if:" $1 $2
  local r1 r2 r3 r4 r5 r6 r7 r8
  car $1 r20
  r1=$r20
  cdr $1 r20
  cdr $r20 r21
  cdr $r21 r21
  car $r20 r20
  r2=$r20
  r3=$r21
  cdr $1 r20 
  cdr $r20 r20 
  car $r20 r20
  if [ $r20 != $false ]; then
    push $r2 $r3 r20 
  else
    push $r1 $r3 r20
  fi
  push "do" $r20 r21
  eval $2=$r21
}

combinator_trace=$true
combinator_trace(){
  log=$true
  eval $2=$1
}

combinator_dec=$true
combinator_dec(){
  local r1 r2 r3
  car $1 r20
  r1=$r20
  r1=$(( $r1 - 1 ))
  combinator_drop $1 r21
  cons $r1 $r21 $2
}

combinator_inc=$true
combinator_inc(){
  local r1 r2 r3
  car $1 r20
  r1=$r20
  r1=$(( $r1 + 1 ))
  combinator_drop $1 r21
  cons $r1 $r21 $2
}

combinator_rot=$true
combinator_rot(){
  local r1 r2 r3
  car $1 r20
  r1=$r20
  cdr $1 r20
  car $r20 r20
  r2=$r20
  cdr $1 r20
  cdr $r20 r20
  cons $r1 $r20 r20
  cons $r2 $r20 r20
  eval $2=$r20
}

combinator_str=$true
combinator_str(){
    combinator_pop $1 $2
}

combinator_push1=$true
combinator_push1(){
  local r1 r2 r3 r4 r5
  car $1 r20
  cons $r20 $STACK1 STACK1
  cdr $1 r20
  eval $2=$r20
}

combinator_pop1=$true
combinator_pop1(){
  local r1 r2 r3
  car $STACK1 r20
  cons $r20 $1 r20
  r1=$r20
  cdr $STACK1 STACK1
  eval $2=$r1
}

combinator_eq=$true
combinator_eq(){
  local r1 r2 r3 r4
  car $1 r20
  r1=$r20
  cdr $1 r20
  car $r20 r20
  r2=$r20
  cdr $1 r20
  cdr $r20 r20
  r3=$r20
  if [ $r1 = $r2 ]; then
    push $true $r3 r20
  else
    push $false $r3 r20
  fi
  eval $2=$r20
}

func_call(){
  [ ! -z $log ] && echo "func_call:" $1 $2 $3
  local r1 r2 r3 r4 r5
  r1=$1
  r2=$2
  while true; do
    [ $r1 = $nil ] && break
    car $r1 r20
    r3=$r20
    push $r3 $r2 r20
    r2=$r20
    cdr $r1 r20
    r1=$r20
  done
  eval $3=$r2
}

reify_block(){
  local r1 r2 r3 r4 r5 r6 r7 r8
  r1=$1
  r2=1
  r4=$nil
  while true; do
    [ $r2 -eq 0 ] && break
    car $r1 r20
    r3=$r20
    [ "$r3" = "]" ] && r2=$(( $r2 + 1))
    [ "$r3" = "[" ] && r2=$(( $r2 - 1))
    cons $r3 $r4 r20
    r4=$r20
    cdr $r1 r20
    r1=$r20
  done
  cdr $r4 r20
  r4=$r20
  cons $r4 $r1 r20
  eval $2=$r20
}

push(){
  [ ! -z $log ] && echo "push:" $1 $2 $3
  local r1 r2 r3 r4 r5
  [ "$1" = "[" ] && quoted=$(( $quoted + 1 ))
  if [ "$1" != "[" ] && [ "$1" != "]" ]; then
    local name="combinator_"$1
    [ "$1" = "." ] && name="combinator_drop"
    local lookup=`eval echo "$"$name`
    local blockp=`eval echo "$"$name"_block"`
  fi
  if [ $quoted -eq 0 ] && [ "$lookup" = $true ]; then
    if [ ! -z "$blockp" ]; then
      func_call $blockp $2 $3
    else
      $name $2 $3
    fi
  else
    cons "$1" $2 $3
  fi
  [ "$1" = "]" ] && quoted=$(( $quoted - 1 ))
  if [ "$1" = "]" ] && [ $quoted -eq 0 ]; then
    reify_block $2 r20
    eval $3=$r20
  fi
}


STACK=$nil
STACK1=$nil
quoted=0
comment=$false
while read IN; do
  r=`expr "$IN" : "#"`
  if [ $r -eq 0 ]; then
    for i in $IN; do
      [ "$i" = "(" ] && comment=$true
      [ $comment = $false ] && push $i $STACK STACK
      [ "$i" = ")" ] && comment=$false
    done
  fi
done
exit 0