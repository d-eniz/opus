clf
data_array = data_plot;
max_length = 30; % length of scan in cm

fluorescence_array(:,1) = [(max_length / length(data_array)) : (max_length / length(data_array)) : max_length];
fluorescence_array(:,2) = data_array;

for k = 1:length(fluorescence_array)
    x = fluorescence_array(k,1); % temp
    y = fluorescence_array(k,2); % temp
    fluorescence_array(k,3) = fluorescence_array(k,2) * 1/(-0.04315*(1-exp(-0.2237*fluorescence_array(k,1)))+0.3545);
end

stdev_original = std(fluorescence_array(:,2));
stdev_normalised = std(fluorescence_array(:,3));
stdev_decrease_percent = abs(100 * (std(fluorescence_array(:,3)) - std(fluorescence_array(:,2)))/std(fluorescence_array(:,2)));

shift = fluorescence_array(1,3)-fluorescence_array(1,2);
for k = 1:length(fluorescence_array)
    fluorescence_array(:,4) = fluorescence_array(:,3) - shift;
end

plot(fluorescence_array(:,1),fluorescence_array(:,2))
hold on
plot(fluorescence_array(:,1),fluorescence_array(:,4))
legend("Original data", "Normalised data")
text(1,0.305,"Standard deviation decrease: " + stdev_decrease_percent + "%")
xlabel("Distance (cm)")
ylabel("Fluorescence (arbitrary units)")

%{
- Fluorescence array -
Col 1: Indicates distance in cm
Col 2: Fluorescence in arbitrary units
Col 3: Normalised fluorescence data
Col 4: Normalised data shifted to original data origin
Col 5: Depth of object at given distance (OpUS data) - i have not done
this yet
%}

