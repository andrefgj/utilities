#!/bin/bash
# POSIX
######################################################################################
# Use esse script para determinar qual a melhor opção de compra: ou à prazo ou à vista
######################################################################################

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



DESCONTO_A_VISTA=`echo "scale=4;$TOTAL_A_PRAZO - $TOTAL_A_VISTA" | bc`
VALOR_PARCELA=`echo "scale=4;$TOTAL_A_PRAZO / $PARCELAS" | bc`
RENDIMENTO_A_PRAZO=0
RENDIMENTO_A_VISTA=0
TAXA_POUPANCA=`echo "scale=4;$SELIC * 0.7" | bc`
SALDO_A_PRAZO=`echo "scale=4;$TOTAL_A_PRAZO - $VALOR_PARCELA" | bc`
SALDO_A_VISTA=$DESCONTO_A_VISTA


for (( c=1; c<=$PARCELAS; c++ ))
do  
    # echo "loop: "$c

    RENDIMENTO_MENSAL_A_PRAZO=`echo "scale=4;$SALDO_A_PRAZO / 100 * $TAXA_POUPANCA" | bc`
    RENDIMENTO_A_PRAZO=`echo "scale=4;$RENDIMENTO_A_PRAZO + $RENDIMENTO_MENSAL_A_PRAZO" | bc`
    SALDO_A_PRAZO=`echo "scale=4;$SALDO_A_PRAZO - $VALOR_PARCELA" | bc`


    RENDIMENTO_MENSAL_A_VISTA=`echo "scale=4;$SALDO_A_VISTA / 100 * $TAXA_POUPANCA" | bc`
    RENDIMENTO_A_VISTA=`echo "scale=4;$RENDIMENTO_A_VISTA + $RENDIMENTO_MENSAL_A_VISTA" | bc`
    SALDO_A_VISTA=`echo "scale=4;$SALDO_A_VISTA + $RENDIMENTO_MENSAL_A_VISTA" | bc`
done




echo "Taxa de Rendimento Poupança: $TAXA_POUPANCA
Valor Total à vista: $TOTAL_A_VISTA
Valor Total à prazo: $TOTAL_A_PRAZO
Desconto à vista: $DESCONTO_A_VISTA
Rendimento a prazo: $RENDIMENTO_A_PRAZO
Rendimento a vista: $SALDO_A_VISTA

"
# echo `echo "$RENDIMENTO_A_PRAZO > $SALDO_A_VISTA" | bc`
if [ `echo "$RENDIMENTO_A_PRAZO > $SALDO_A_VISTA" | bc` -eq 1 ] ; then
    echo "###################################"
    echo "# Melhor opção de compra: À PRAZO #"
    echo "###################################"
else
    echo "###################################"
    echo "# Melhor opção de compra: À VISTA #"
    echo "###################################"
fi

