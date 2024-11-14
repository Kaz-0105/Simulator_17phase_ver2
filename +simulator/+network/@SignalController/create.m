function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % SignalControllersクラスのComオブジェクトを取得
        SignalControllers = obj.get('SignalControllers').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = SignalControllers.ItemByKey(obj.id);
    
    elseif strcmp(property_name, 'Intersection')
        % SignalGroupを走査
        for signal_group_id = obj.SignalGroups.getKeys()
            SignalGroup = obj.SignalGroups.itemByKey(signal_group_id);

            % Roadクラスの取得
            Road = SignalGroup.get('Road');

            % 最初の調査かどうかで分岐
            if isempty(obj.Intersection)
                % Intersectionクラスの設定
                obj.Intersection = Road.get('Intersections').output;
                obj.Intersection.set('SignalController', obj);
            else
                % Intersectionクラスのバリデーション
                if obj.Intersection.get('id') ~= Road.get('Intersections').output.get('id')
                    error('Intersection ID is not same.');
                end
            end
        end
    else
        error('Property name is invalid.');
    end
end