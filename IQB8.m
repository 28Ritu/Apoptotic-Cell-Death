folders = {'CancerCell_Type1', 'CancerCell_Type2', 'HealthyCells'};
prob = [];                  % Probability array
mean = 0;
for i = 1:3                 % Loop to iterate over the folders
    celldeaths = [];        % Cell-death array to store no. of dead cells
    probability = 0;
    for j = 1:16            % Loop for 16-MC runs 
        for k = 1:16        % Loop to iterate over 16 randomly selected files
            apoptosis = 0;
            survival = 0;
            time = 0;
            for m = 1:16    % Loop to select a file randomly
                filenum = randi(64);
                file = strcat('output', num2str(filenum));
                filename = fullfile(folders{i}, file);
                fileID = fopen(filename, 'r');
                lastline = '';
                offset = 1;
                fseek(fileID, -offset, 'eof');
                newchar = fread(fileID, 1, '*char');
                while (~strcmp(newchar,char(10))) || (offset == 1)
                      lastline = [newchar lastline];        % Add the character to a string
                      offset = offset + 1;
                      fseek(fileID,-offset,'eof');          % Seek to the file end, minus the offset
                      newchar = fread(fileID,1,'*char');
                end
                tokens = str2num(sprintf(lastline));
                caspase3(k*m) = tokens(6);
                if (tokens(6) > 80)                   % Decide if the cell survives or dies depending upon the caspase-3 activation threshold (= 80)
                    apoptosis = apoptosis + 1;
                    probability = probability + 1;
                else
                    survival = survival + 1;
                end
                fclose(fileID);
            end
            celldeaths = [celldeaths, apoptosis];
        end
    end
    prob = [prob, probability];
    mean = mean + probability;
    fprintf('Total cell deaths in %s :\n', folders{i});
    disp(celldeaths);
    subplot(1, 3, i);
    histogram(celldeaths);
    title(folders{i});
    xlabel('No. of Cell Deaths');
    ylabel('Frequency');
    fprintf('\n');
end
for p = 1:3
    fprintf('Probability of cell death for %s :\n', folders{p});
    disp(prob(p)/mean);
end