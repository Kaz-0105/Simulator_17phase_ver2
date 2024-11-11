classdef DataCollectionMeasurements < utils.class.Container
    properties
        Config;
    end
    
    methods
        function obj = DataCollectionMeasurements(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % NetworkクラスとConfigクラスを取得
                obj.set('Network', UpperClass);
                obj.Config = obj.Network.get('Config');

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % LinkRoadMapを作成
                obj.create('LinkRoadMap');

                % 要素クラスを作成
                obj.create('Elements');

                % LinkRoadMapの削除
                obj.delete('LinkRoadMap');

            elseif isa(UpperClass, 'simulator.network.Road')
                % RoadクラスとConfigクラスを取得
                obj.set('Road', UpperClass);
                obj.Config = obj.Road.get('Config');
            end

            
        end
    end

    methods
        create(obj, property_name);
    end
end