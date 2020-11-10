#!/bin/bash

mkdir -p compiled images

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

echo "Creating horas.fst"
fstcompose compiled/horas_sem_numeros.fst compiled/converter.fst | fstrmepsilon | fstarcsort > compiled/horas.fst 
echo "Creating minutos.fst"
fstcompose compiled/minutos_sem_numeros.fst compiled/converter.fst | fstrmepsilon | fstarcsort > compiled/minutos.fst

echo "Creating text2num.fst"
fstconcat compiled/convert_e.fst compiled/minutos.fst | fstarcsort > compiled/text2num_aux.fst
fstconcat compiled/horas.fst  compiled/text2num_aux.fst | fstarcsort > compiled/text2num.fst

echo "Creating lazy2num.fst"
fstunion compiled/text2num_aux.fst compiled/add_00.fst | fstarcsort > compiled/lazy2num_aux.fst
fstconcat compiled/horas.fst compiled/lazy2num_aux.fst | fstarcsort > compiled/lazy2num.fst
rm compiled/text2num_aux.fst
rm compiled/lazy2num_aux.fst

echo "Creating rich2text.fst"
fstconcat compiled/horas.fst compiled/convert_e.fst | fstarcsort > compiled/rich2text_aux.fst
fstproject --project_type=input compiled/rich2text_aux.fst | fstarcsort > compiled/rich2text_aux2.fst
fstunion compiled/meias.fst compiled/quartos.fst | fstarcsort > compiled/rich2text_aux3.fst
fstconcat compiled/rich2text_aux2.fst compiled/rich2text_aux3.fst | fstarcsort > compiled/rich2text.fst
rm compiled/rich2text_aux.fst
rm compiled/rich2text_aux2.fst
rm compiled/rich2text_aux3.fst

echo "Creating rich2num.fst"
fstcompose compiled/rich2text.fst compiled/lazy2num.fst | fstarcsort > compiled/rich2num_aux.fst
fstunion compiled/lazy2num.fst compiled/rich2num_aux.fst | fstarcsort > compiled/rich2num.fst
rm compiled/rich2num_aux.fst

echo "Creating num2text.fst"
fstinvert compiled/text2num.fst | fstarcsort > compiled/num2text.fst

for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

echo "Testing the transducer 'converter' with the input 'tests/numero.txt'"
fstcompose compiled/numero.fst compiled/converter.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt


echo "Testing the transducer 'horas' with the input 'tests/horas_test.txt'"
fstcompose compiled/horas_test.fst compiled/horas.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'minutos' with the input 'tests/minutos_test.txt'"
fstcompose compiled/minutos_test.fst compiled/minutos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'meias' with the input 'tests/meias_test.txt'"
fstcompose compiled/meias_test.fst compiled/meias.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'quartos' with the input 'tests/quartos_test.txt'"
fstcompose compiled/quartos_test.fst compiled/quartos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'text2num' with the input 'tests/text2num_test.txt'"
fstcompose compiled/text2num_test.fst compiled/text2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'lazy2num' with the input 'tests/text2num_test.txt'"
fstcompose compiled/text2num_test.fst compiled/lazy2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'lazy2num' with the input 'tests/lazy2num_test.txt'"
fstcompose compiled/lazy2num_test.fst compiled/lazy2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2text' with the input 'tests/rich2text_test.txt'"
fstcompose compiled/rich2text_test.fst compiled/rich2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/lazy2num_test.txt'"
fstcompose compiled/lazy2num_test.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/rich2text_test.txt'"
fstcompose compiled/rich2text_test.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/text2num_test.txt'"
fstcompose compiled/text2num_test.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/num2text_test.txt'"
fstcompose compiled/num2text_test.fst compiled/num2text.fst  | fstshortestpath --nshortest=1 | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt