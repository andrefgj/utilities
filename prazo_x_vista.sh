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
                PARCELAS=$2
                shift
            else
                die 'ERROR: "x|--parcelas" requires a non-empty option argument.'
            fi            
            ;;
        -v|--total-a-vista)
            #echo "total a vista: $2"
            if [ "$2" ]; then
                TOTAL_A_VISTA=$2
                shift
            else
                die 'ERROR: "-v|--total-a-vista" requires a non-empty option argument.'
            fi
            ;;
        -p|--total-a-prazo)
            #echo "total a prazo: $2"
            if [ "$2" ]; then
                TOTAL_A_PRAZO=$2
                shift
            else
                die 'ERROR: "-p|--total-a-prazo" requires a non-empty option argument.'
            fi
            ;;
        -s|--selic)
            #echo "selic: $2"
            if [ "$2" ]; then
                SELIC=$2
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


calcularIndicePoupanca(){
    if [ `echo "$SELIC > 8.5" | bc` -eq 1  ]; then
        echo 0.5
    else
        echo `echo "scale=4;$SELIC * 0.7" | bc`
    fi
}


DESCONTO_A_VISTA=`echo "scale=2;$TOTAL_A_PRAZO - $TOTAL_A_VISTA" | bc`
VALOR_PARCELA=`echo "scale=2;$TOTAL_A_PRAZO / $PARCELAS" | bc`
RENDIMENTO_A_PRAZO=0
RENDIMENTO_A_VISTA=0
TAXA_POUPANCA=`calcularIndicePoupanca`

# Matriz baseada na seguinte estrutura:
# parcelas    |   saldo   |   rendimento Mensal
# 1           |   990.89  |   45.09
# 2           |   941.78  |   42.85
# #           |   ###.##  |   ##.##
declare -a prazo
declare -a vista


# Popular matrizes prazo e vista
for (( i=1; i<=$PARCELAS; i++ ))
do  
    if [ $i -eq 1 ]; then
        prazo[$i,1]=`echo "scale=4;$TOTAL_A_VISTA - $VALOR_PARCELA" | bc`
        prazo[$i,2]=`echo "scale=4;${prazo[$i,1]} / 100 * $TAXA_POUPANCA" | bc`
    else
        prazo[$i,1]=`echo "scale=4;${prazo[$(($i-1)),1]} + ${prazo[$(($i-1)),2]} - $VALOR_PARCELA" | bc`
        prazo[$i,2]=`echo "scale=4;${prazo[$i,1]} / 100 * $TAXA_POUPANCA" | bc`
    fi


    if [ $i -eq 1 ]; then
        vista[$i,1]=$DESCONTO_A_VISTA
        vista[$i,2]=`echo "scale=4;${vista[$i,1]} / 100 * $TAXA_POUPANCA" | bc`
    else
        vista[$i,1]=`echo "scale=4;${vista[$(($i-1)),1]} + ${vista[$(($i-1)),2]}" | bc`
        vista[$i,2]=`echo "scale=4;${vista[$i,1]} / 100 * $TAXA_POUPANCA" | bc`
    fi
done


RENDIMENTO_A_PRAZO=`echo "scale=4;${prazo[$PARCELAS,1]} + ${prazo[$PARCELAS,2]}" | bc`
RENDIMENTO_A_VISTA=`echo "scale=4;${vista[$PARCELAS,1]} + ${vista[$PARCELAS,2]}" | bc`


echo "Taxa de Rendimento Poupança: $TAXA_POUPANCA
Valor Total à vista: $TOTAL_A_VISTA
Valor Total à prazo: $TOTAL_A_PRAZO
Desconto à vista: $DESCONTO_A_VISTA
Rendimento a prazo: $RENDIMENTO_A_PRAZO
Rendimento a vista: $RENDIMENTO_A_VISTA

"

if [ `echo "$RENDIMENTO_A_PRAZO > $RENDIMENTO_A_VISTA" | bc` -eq 1 ]; then
    echo "######################################"
    echo "# A melhor opção de pagamento é À PRAZO #"
    echo "######################################
       
    "
else
    echo "#########################################"
    echo "# A melhor opção de pagamento é À VISTA #"
    echo "#########################################
       
    "
fi

