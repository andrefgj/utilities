import array

parcelas = 12
selic = 6.5
total_a_prazo = 1305.63
total_a_vista = 1109.78



desconto_a_vista = total_a_prazo - total_a_vista
valor_parcela = total_a_prazo / parcelas
rendimento_a_prazo = None
rendimento_a_vista = None
taxa_poupanca = None
prazo = []
vista = []


def calcular_indice_poupanca(selic):
    taxa_poupanca = 0
    if selic > 8.5:
        return 0.5
    else:
        return selic * 0.7

taxa_poupanca = calcular_indice_poupanca(selic)

for i in range(1, parcelas):
    if i == 1:
        saldo = total_a_vista - valor_parcela
        rendimento_mensal = saldo / 100 * taxa_poupanca
        prazo.insert(0, [saldo, rendimento_mensal])
    else:
        saldo = prazo[i - 2][0] + prazo[i - 2][1] - valor_parcela
        rendimento_mensal = saldo / 100 * taxa_poupanca
        prazo.insert(i,[saldo, rendimento_mensal])


for j in range(parcelas):
    if j == 0:
        saldo = desconto_a_vista
        rendimento_mensal = saldo / 100 * taxa_poupanca
        vista.insert(0, [saldo, rendimento_mensal])
    else:
        saldo = vista[j - 1][0] + vista[j - 1][1] 
        rendimento_mensal = saldo / 100 * taxa_poupanca
        vista.insert(j, [saldo, rendimento_mensal])


rendimento_a_prazo = prazo[parcelas - 2][0] + prazo[parcelas - 2][1]
rendimento_a_vista = vista[parcelas -1][0] + vista[parcelas - 1][1]

print('Taxa de Rendimento poupança: ' + str(taxa_poupanca))
print('Valor Total à vista: ' + str(total_a_vista))
print('Valor Total à prazo: ' + str(total_a_prazo))
print('Desconto à vista: ' + str(format(desconto_a_vista, '.2f')))
print('Rendimento poupança a prazo: ' + str(format(rendimento_a_prazo, '.2f'))) 
print('Rendimento poupança a vista: ' + str(format(rendimento_a_vista, '.2f')))
print('\n')

if rendimento_a_prazo > rendimento_a_vista:
    print('#########################################')
    print('# A melhor opção de pagamento é À PRAZO #')
    print('#########################################')
    print('\n')
else:
    print('#########################################')
    print('# A melhor opção de pagamento é À VISTA #')
    print('#########################################')
    print('\n')
