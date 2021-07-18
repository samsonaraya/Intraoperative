function [x,y] = PullDVH(Path)

csv_file = fileread(Path);


filebyline = regexp(csv_file, '\n', 'split');
filebyfield = regexp(filebyline, ';', 'split');
numfields = cellfun(@length, filebyfield);
maxfields = max(numfields);
fieldpattern = repmat({[]}, 1, maxfields);
firstN = @(S,N) S(1:N);
filebyfield = cellfun(@(S) firstN([S,fieldpattern], maxfields), filebyfield, 'Uniform', 0);
%switch from cell vector of cell vectors into a 2D cell
fieldarray = vertcat(filebyfield{:});
%convert all fields to numeric
numarray = str2double(fieldarray(38:118,:));
%switch to cell array of numbers
outarray = num2cell(numarray);

x = cell2mat(outarray(:,1));
y = cell2mat(outarray(:,4));

end


