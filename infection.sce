// Esta função gera un grid de nlin por ncol
// para simular a população de uma localidade
// densidade é a probabilidade de cada célula estar ocupada
// prob de uma célula ocupada 


// 1 significa célula vazia
// 2 significa célula ocupada por indivíduo sadio
// 3 significa célula ocupada por indivíduo infectado
function [grid] = gera_populacao_inicial(nlin,ncol,desidade,prob)
    //Gera a população inicial de acordo a função de probabilidade binomial
    grid = grand(nlin,ncol,'bin',1,desidade)
    nindividuos = sum(grid==1) 
    //pelo menos um doente na população
    ndoentes = max(1,int(nindividuos*prob))
    //seleciona aleatóriamente um indivíduos como doentes
    doentes = samwr(ndoentes,1,find(grid==1))
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
        infectado = rand() < prob
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


nlin = 50;
ncol = 50;
densidade = 0.8;
inicial_infectaco = 0.02;
prob_infeccao = 0.8;
prob_cura = 0.3;
prob_morte = 0.01;

grid = gera_populacao_inicial(nlin,ncol,densidade,inicial_infectaco)

for iteracao = 1:100
    Matplot(grid)
    xtitle(sprintf("Iteração %d",iteracao))
    new_pop = grid
    for x=1:nlin
        for y=1:ncol
            if grid(x,y)==2 & foi_infectado(grid,x,y,prob_infeccao)
                new_pop(x,y) = 3
            end
            if grid(x,y)==3 & foi_curado(grid,x,y,prob_cura)
                new_pop(x,y) = 4
            end
            if grid(x,y)==3 & new_pop(x,y)~=4 & faleceu(grid,x,y,prob_morte)
                new_pop(x,y) = 5
            end
        end
    end
    grid=new_pop
end
