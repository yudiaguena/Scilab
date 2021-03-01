// Esta função gera un grid de nlin por ncol
// para simular a população de uma localidade
// densidade é a probabilidade de cada célula estar ocupada
// prob de uma célula ocupada 


// 1 significa célula vazia
// 2 significa célula ocupada por indivíduo sadio
// 3 significa célula ocupada por indivíduo infectado
function [grid,nindividuos,ndoentes] = gera_populacao_inicial(nlin,ncol,desidade,prob)
    //Gera a população inicial de acordo a função de probabilidade binomial
    grid = grand(nlin,ncol,'bin',1,desidade)
    nindividuos = sum(grid==1) 
    //pelo menos um doente na população
    ndoentes = max(1,int(nindividuos*prob))
    //seleciona aleatóriamente um indivíduos como doentes
    doentes = samwr(ndoentes,1,find(grid==1))
    //caracteriza a aleatoriedade da escolha dos doentes na amostra
    grid(doentes) = 2
    //soma 1 em cada célula par poder visualizar
    grid = grid+1
endfunction


function [infectado] = foi_infectado(grid,x,y,prob)
    [nlin,ncol] = size(grid)
    vizinhos_infectados = 0
    for i=[-1,1]
        vizinho_x = modulo(x + i,nlin)
        vizinho_y = modulo(y + i,ncol)
        if vizinho_x == 0
            vizinho_x = nlin
        end
        if vizinho_y == 0
            vizinho_y = ncol
        end
        if grid(vizinho_x,y)==3
            vizinhos_infectados = vizinhos_infectados+1
        end
        if grid(x,vizinho_y)==3
            vizinhos_infectados = vizinhos_infectados+1
        end
    end

    if vizinhos_infectados > 0
        infectado = rand()<0.9
    else
        infectado = %f
    end
endfunction

function [curado] = foi_curado(grid,x,y,prob)
    curado = rand() < prob
endfunction

function [falecido] = faleceu(grid,x,y,prob)
    falecido = rand() < prob
endfunction


nlin = 50;//número de linhas da matriz - indica população
ncol = 50;
densidade = 0.8;
inicial_infectaco = 0.02;
prob_infeccao = 0.8;
prob_cura = 0.3;
prob_morte = 0.1;
prob_anticorpo = 0.005

evolucaoInfeccao = zeros(1:100)
evolucaoCurados = zeros(1:100)
evolucaoMortos = zeros(1:100)
evolucaonNaoInfectados = zeros(1:100)

[grid,nPessoas,nInfectados] = gera_populacao_inicial(nlin,ncol,densidade,inicial_infectaco)
disp(nPessoas)
disp(nInfectados)

nNaoInfectados = length(find(grid==2))
disp(nNaoInfectados)

nMortos=0
nCurados=0

scf(0)
for iteracao = 1:100//dias da infecção
    Matplot(grid)
    xtitle(sprintf("Progressão da infecção %d",iteracao))
    new_pop = grid
    for x=1:nlin
        for y=1:ncol
            if grid(x,y)==2 & foi_infectado(grid,x,y,prob_infeccao)
                new_pop(x,y) = 3 //3 é infectado
                nInfectados = nInfectados + 1
                nNaoInfectados = nNaoInfectados - 1
            end
            if grid(x,y)==3 & foi_curado(grid,x,y,prob_cura)
                new_pop(x,y) = 4// 4 é curado
                nCurados = nCurados + 1
                nInfectados = nInfectados - 1
            end
            
            if grid(x,y)==3 & new_pop(x,y)~=4 & faleceu(grid,x,y,prob_morte)
                new_pop(x,y) = 5// 5 é morto
                nMortos = nMortos + 1
                nInfectados = nInfectados - 1
            end
        end
    end
    grid=new_pop
    evolucaoInfeccao(iteracao) = nInfectados
    evolucaoCurados(iteracao) = nCurados
    evolucaoMortos(iteracao) = nMortos
    evolucaonNaoInfectados (iteracao) = nNaoInfectados
end

scf(1)
plot(1:100,evolucaoInfeccao, 'g-');
plot(1:100,evolucaoCurados,'c-');
plot(1:100,evolucaoMortos, 'r-');
plot(1:100,evolucaonNaoInfectados,'b-');

title("Gráfico de Progressão Temporal da Infecção");
xlabel("Tempo (dias)");
ylabel("Número de Indivíduos");
legend('Infecção', 'Curados', 'Mortos', 'Não Infectados')
