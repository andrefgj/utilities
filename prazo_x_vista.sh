#!/bin/bash
# POSIX
#####################################################################################################################################
# Use esse script para determinar qual a melhor opção de pagamento (ou à prazo, ou à vista) considerando manter o montante em poupança
#####################################################################################################################################

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

while :; do
    case $1 in
        -h|-\?|--help)
            #echo "$package - attempt to capture frames"
            echo " "
            echo "uso: $programname [-h] -v TOTAL_A_VISTA -p TOTAL_A_PRAZO -x NUMERO_DE_PARCELAS -s SELIC"
            echo " "
            echo "opções:"
            echo "-h, --help                sumário de ajuda"
            echo "-v, --total-a-vista       total à vista"
            echo "-p, --total-a-prazo       total à prazo"
            echo "-x, --parcelas            número de parcelas"
            echo "-s, --selic               taxa selic atual"
            exit 0
            ;;
        -x|--parcelas)       # Takes an option argument; ensure it has been specified.
            #echo "numero de parcelas: $2"
            if [ "$2" ]; then
                parcelas=$2
                shift
            else
                die 'ERROR: "x|--parcelas" requires a non-empty option argument.'
            fi            
            ;;
        -v|--total-a-vista)
            #echo "total a vista: $2"
            if [ "$2" ]; then
                total_a_vista=$2
                shift
            else
                die 'ERROR: "-v|--total-a-vista" requires a non-empty option argument.'
            fi
            ;;
        -p|--total-a-prazo)
            #echo "total a prazo: $2"
            if [ "$2" ]; then
                total_a_prazo=$2
                shift
            else
                die 'ERROR: "-p|--total-a-prazo" requires a non-empty option argument.'
            fi
            ;;
        -s|--selic)
            #echo "selic: $2"
            if [ "$2" ]; then
                selic=$2
                shift
            else
                die 'ERROR: "-s|--selic" requires a non-empty option argument.'
            fi
            #echo $s
            ;;
        
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done


calcular_indice_poupanca(){
    if [ `echo "$selic > 8.5" | bc` -eq 1  ]; then
        echo 0.5
    else
        echo `echo "scale=4;$selic * 0.7" | bc`
    fi
}


desconto_a_vista=`echo "scale=2;$total_a_prazo - $total_a_vista" | bc`
valor_parcela=`echo "scale=2;$total_a_prazo / $parcelas" | bc`
rendimento_a_prazo=0
rendimento_a_vista=0
taxa_poupanca=`calcular_indice_poupanca`

# Matrizes baseada na seguinte estrutura:
# parcelas    |   saldo   |   rendimento Mensal
# 1           |   990.89  |   45.09
# 2           |   941.78  |   42.85
# #           |   ###.##  |   ##.##
declare -a prazo
declare -a vista


# Popular matrizes prazo e vista
for (( i=1; i<=$parcelas; i++ ))
do  
    if [ $i -eq 1 ]; then
        prazo[$i,1]=`echo "scale=4;$total_a_vista - $valor_parcela" | bc`
        prazo[$i,2]=`echo "scale=4;${prazo[$i,1]} / 100 * $taxa_poupanca" | bc`
    else
        prazo[$i,1]=`echo "scale=4;${prazo[$(($i-1)),1]} + ${prazo[$(($i-1)),2]} - $valor_parcela" | bc`
        prazo[$i,2]=`echo "scale=4;${prazo[$i,1]} / 100 * $taxa_poupanca" | bc`
    fi


    if [ $i -eq 1 ]; then
        vista[$i,1]=$desconto_a_vista
        vista[$i,2]=`echo "scale=4;${vista[$i,1]} / 100 * $taxa_poupanca" | bc`
    else
        vista[$i,1]=`echo "scale=4;${vista[$(($i-1)),1]} + ${vista[$(($i-1)),2]}" | bc`
        vista[$i,2]=`echo "scale=4;${vista[$i,1]} / 100 * $taxa_poupanca" | bc`
    fi
done


rendimento_a_prazo=`echo "scale=4;${prazo[$parcelas,1]} + ${prazo[$parcelas,2]}" | bc`
rendimento_a_vista=`echo "scale=4;${vista[$parcelas,1]} + ${vista[$parcelas,2]}" | bc`


echo "Taxa de Rendimento Poupança: $taxa_poupanca
Valor Total à vista: $total_a_vista
Valor Total à prazo: $total_a_prazo
Desconto à vista: $desconto_a_vista
Rendimento a prazo: $rendimento_a_prazo
Rendimento a vista: $rendimento_a_vista

"

if [ `echo "$rendimento_a_prazo > $rendimento_a_vista" | bc` -eq 1 ]; then
    echo "#########################################"
    echo "# A melhor opção de pagamento é À PRAZO #"
    echo "#########################################
       
    "
else
    echo "#########################################"
    echo "# A melhor opção de pagamento é À VISTA #"
    echo "#########################################
       
    "
fi

