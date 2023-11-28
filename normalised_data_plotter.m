clf
stdev_original = std(fluorescence_array(:,2));
stdev_normalised = std(fluorescence_array(:,5));
stdev_decrease_percent = abs(100 * (std(fluorescence_array(:,5)) - std(fluorescence_array(:,2)))/std(fluorescence_array(:,2)));

plot(fluorescence_array(:,1),fluorescence_array(:,2))
hold on
plot(fluorescence_array(:,1),fluorescence_array(:,5))
legend("Original data", "Normalised data")
text(1,0.305,"Standard deviation decrease: " + stdev_decrease_percent + "%")
xlabel("Distance (cm)")
ylabel("Fluorescence (arbitrary units)")

%{
- Fluorescence array columns -
1 - Distance cm
2 - Fluorescence au
3 - Depth cm
4 - Normalised fluorescence au
5 - Shifted and normalised
%}