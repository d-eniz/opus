data_array = data_plot;

a = 1:length(data_array);
idx = 1;
for x = data_array
    a(2, idx) = 1/(-0.04315*(1-exp(-0.02237*x))+0.3545);
    idx = idx + 1;
end

a(2,:) = a(2,:) - mean(a(2,:)) + mean(data_array);
imagesc(a(2,:));
colorbar;
caxis([mean(data_array) - 2.5*std(data_array) mean(data_array) + 2.5*std(data_array)]);
colormap hot