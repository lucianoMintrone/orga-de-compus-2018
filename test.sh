echo "Tests begin"

make

OK_COUNTER=0
FAIL_COUNTER=0


function validation {
  if [[ -z $1 ]]; then
    echo "  Test OK"
    OK_COUNTER=$(( $OK_COUNTER + 1 ))
  else
    echo "  Test Fail"
    FAIL_COUNTER=$(( $FAIL_COUNTER + 1 ))
  fi
}

echo "Order number and send to stdout"
# cp tests/test1.txt tests/aux/test1out.txt
./qsort -o - tests/test1.txt > aux/test1out.txt
RESULT=$(diff tests/aux/test1out.txt tests/test1result.txt)
validation $RESULT

echo "Test Summary"
echo "  $OK_COUNTER Test OK"
echo "  $FAIL_COUNTER Test Fail"
rm tests/aux/*
