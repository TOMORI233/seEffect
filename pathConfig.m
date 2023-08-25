function DATAROOTPATH = pathConfig(DATAROOTPATH)
    narginchk(0, 1);

    if nargin < 1
        DATAROOTPATH = 'Data\20230823-2023082302\';
    end
    
    return;
end