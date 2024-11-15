classdef DataCollectionMeasurements < utils.class.Container
    properties
        Config;
        Timer;
    end
    
    methods
        function obj = DataCollectionMeasurements(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % NetworkクラスとConfigクラスとTimerクラスを取得
                obj.set('Network', UpperClass);
                obj.Config = obj.Network.get('Config');
                obj.Timer = obj.Network.get('Timer');

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % Roadクラスにおいて必要のないDataCollectionMeasurementsを削除
                obj.get('Network').get('Roads').delete('DataCollections');

            elseif isa(UpperClass, 'simulator.network.Road')
                % RoadクラスとConfigクラスを取得
                obj.set('Road', UpperClass);
                obj.Config = obj.Road.get('Config');
                obj.Timer = obj.Road.get('Timer');
            end
        end
    end

    methods
        create(obj, property_name);
    end
end