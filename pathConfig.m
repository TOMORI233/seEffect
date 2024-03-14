function DATAROOTPATH = pathConfig(DATAROOTPATH)
    narginchk(0, 1);

    if nargin < 1
        DATAROOTPATH = 'Data\raw\20230904-2023090401\';
    end
    
    return;
end