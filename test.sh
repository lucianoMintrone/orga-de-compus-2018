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
    echo $1
    FAIL_COUNTER=$(( $FAIL_COUNTER + 1 ))
  fi
}

echo "Order number and send to stdout"
./qsort -n -o - -i tests/test1.txt > tests/aux/test1_out.txt
RESULT=$(diff tests/aux/test1_out.txt tests/test1_result.txt)
validation $RESULT

echo "Order number with many digits and send to stdout"
./qsort -n -o - -i tests/test2.txt > tests/aux/test2_out.txt
RESULT=$(diff tests/aux/test2_out.txt tests/test2_result.txt)
validation $RESULT

echo "Empty file test"
./qsort -o - -i tests/empty.txt > tests/aux/empty_out.txt
RESULT=$(diff tests/aux/empty_out.txt tests/empty_result.txt)
validation $RESULT


echo "Extern tests begin"

echo "Alice test"
./qsort -o - -i tests/alice.txt > tests/aux/alice_out.txt
RESULT=$(diff tests/aux/alice_out.txt tests/alice_result.txt)
validation $RESULT

echo "Numeros test"
./qsort -n -o - -i tests/numeros.txt > tests/aux/numeros_out.txt
RESULT=$(diff tests/aux/numeros_out.txt tests/numeros_result.txt)
validation $RESULT

echo "Quijote test"
./qsort -o - -i tests/quijote.txt > tests/aux/quijote_out.txt
RESULT=$(diff tests/aux/quijote_out.txt tests/quijote_result.txt)
validation $RESULT

echo "Text test"
./qsort -o - -i tests/text1.txt > tests/aux/text1_out.txt
RESULT=$(diff tests/aux/text1_out.txt tests/text1_result.txt)
validation $RESULT

echo "Zeta test"
./qsort -o - -i tests/zeta.txt > tests/aux/zeta_out.txt
RESULT=$(diff tests/aux/zeta_out.txt tests/zeta_result.txt)
validation $RESULT


echo "Test Summary"
echo "  $OK_COUNTER Test OK"
echo "  $FAIL_COUNTER Test Fail"
rm tests/aux/*
