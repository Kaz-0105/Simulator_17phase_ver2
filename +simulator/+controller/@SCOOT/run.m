function run(obj)
    if strcmp(obj.objective, 'split') || strcmp(obj.objective, 'both')
        obj.update('PhaseSaturationRateMap');
    end

    if strcmp(obj.objective, 'cycle') || strcmp(obj.objective, 'both')
    end
end