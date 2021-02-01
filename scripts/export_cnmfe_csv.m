%% exporting to NIV csv format version 1.1
folder = '';
[filepath,name,ext] = fileparts(neuron.options.name);
prefix = name;

% neurons calcium raw traces
name_c_raw = saveCsv(neuron.C, [folder prefix '_c_raw.csv'], true);

% neurons spike traces
name_spike = saveCsv(neuron.S, [folder prefix '_spike.csv'], true);

% bg image
name_bg_image = saveCsv(neuron.Cn, [folder prefix '_bg_image.csv']);

% spatial components of neurons
name_A = saveCsv(neuron.A, [folder prefix '_A.csv'], true);

% centers of neurons
name_centers = [folder prefix '_centers.csv'];
centers = com(neuron.A, neuron.options.d1, neuron.options.d2);
csvwrite(name_centers, centers);

% meta
name_meta = [folder prefix '_meta.csv'];
fileID = fopen(name_meta,'w');
fprintf(fileID, 'version; 1.1\n');
fprintf(fileID, 'file_c_raw; %s\n',name_c_raw);
fprintf(fileID, 'file_spike; %s\n',name_spike);
fprintf(fileID, 'file_bg_image; %s\n',name_bg_image);
fprintf(fileID, 'file_A; %s\n',name_A);
fprintf(fileID, 'file_centers; %s\n',name_centers);
fprintf(fileID, 'image_width;%d\n', neuron.options.d2);
fprintf(fileID, 'image_height;%d\n', neuron.options.d1);
fprintf(fileID, 'Fs;%d\n', Fs); % FPS
fclose(fileID);


function filename = saveCsv(mat, filename, forceFullMat)
    if ~issparse(mat) || (nargin >= 3 && forceFullMat) 
        dlmwrite(filename, full(mat), ';');
    else
        filename = [filename '_sp'];
        [r, c, v] = find(mat);
        dlmwrite(filename, [r c v], '\t');
    end
end