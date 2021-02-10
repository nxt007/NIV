function useviewneuron2(data, m)


Amask = (data.A~=0);
ind = 1:size(data.c_raw, 2);
ind_trim = false(size(ind));    % indicator of trimming neurons
ind_del = false(size(ind));     % indicator of deleting neurons
ctr = useestCenter(data);         % neuron's centers
% gSiz = ms.Options.gSiz;         % maximum size of a neuron
gSiz = 15;                      % maximum size of a neuron

T = size(data.c_raw, 1);
t = 1:T;
if ~isnan(data.meta.Fs)
    t = t/data.meta.Fs;
    str_xlabel = 'Time (Sec.)';
else
    str_xlabel = 'Frame';
end
sizes = [data.meta.image_height data.meta.image_width];
figure('position', [100, 100, 1024, 512]);
subplot(321); cla;
    useimage(sizes, data.A(:, ind(m)).*Amask(:, ind(m))); %
    axis equal; axis off;
    if ind_del(m)
        title(sprintf('Neuron %d', ind(m)), 'color', 'r');
    else
        title(sprintf('Neuron %d', ind(m)));
    end
    %% zoomed-in view
    subplot(322); cla;
    useimage(sizes, data.A(:, ind(m)).*Amask(:, ind(m))); %
    %     imagesc(reshape(obj.A(:, ind(m)).*Amask(:,ind(m))), obj.options.d1, obj.options.d2));
    axis equal; axis off;
    x0 = ctr(ind(m), 2);
    y0 = ctr(ind(m), 1);
    xlim(x0+[-gSiz, gSiz]*2);
    ylim(y0+[-gSiz, gSiz]*2);
    
    
    %% temporal components
    subplot(3,2,3:4);cla;
    
    plot(t, data.c_raw(:,ind(m)), 'linewidth', 2); hold on;
%     plot(t, data.spike(:,ind(m)), 'r');
    title('Fluorescence Trace');
    xlim([t(1), t(end)]);
    xlabel(str_xlabel);
    
    subplot(3,2,5:6);cla;
    
    plot(t, data.spike(:,ind(m)), 'linewidth', 2);  hold on; 
        
    if isfield(data,'spike2')
        plot(t, data.spike2(:,ind(m)), 'g','linewidth', 1);
    end
    
    if isfield(data,'c_raw2')
        plot(t, data.c_raw2(:,ind(m)), 'r','linewidth', 1);
    end
       plot(t, ms.FiltTraces(:,ind(m))*max(ms.A(:, ind(m))), 'r');
        
    title('Spike Activity');
    xlim([t(1), t(end)]);
    xlabel(str_xlabel);


end

function useimage(sizes, a, min_max)
    if isvector(a)
        a = usereshape(sizes, a, 2);
    end
    if nargin < 3
        imagesc(a);
    else
        imagesc(a, min_max);
    end
end

function Y = usereshape(sizes, Y, dim)
    % reshape the imaging data into diffrent dimensions
    d1 = sizes(1);
    d2 = sizes(2);
    if dim==1
        Y=reshape(Y, d1*d2, []);  %each frame is a vector
    else
        Y = reshape(full(Y), d1, d2, []);    %each frame is an image
    end
end

function center = useestCenter(data)
    center = center_of_mass(data.A, data.meta.image_height, data.meta.image_width);
end

function cm = center_of_mass(A,d1,d2,d3)

% center of mass calculation
% inputs:
% A: d X nr matrix, each column in the spatial footprint of a neuron
% d1, d2, d3: the dimensions of the 2-d (or 3-d) field of view

% output:
% cm: nr x 2 (or 3) matrix, with the center of mass coordinates

    if nargin < 4
        d3 = 1;
    end
    if d3 == 1
        ndim = 2;
    else
        ndim = 3;
    end

    nr = size(A,2);
    Coor.x = kron(ones(d2*d3,1),(1:d1)');
    Coor.y = kron(ones(d3,1),kron((1:d2)',ones(d1,1)));
    Coor.z = kron((1:d3)',ones(d2*d1,1));
    cm = [Coor.x, Coor.y, Coor.z]'*A/spdiags(sum(A)',0,nr,nr);
    cm = cm(1:ndim,:)';
    cm(cm<0) = 0; 
    cm(cm(:,1)>d1, 1) = d1; 
    cm(cm(:,2)>d2, 2) = d2; 
end