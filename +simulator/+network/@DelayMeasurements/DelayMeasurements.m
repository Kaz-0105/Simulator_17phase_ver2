classdef DelayMeasurements < utils.class.Container
    properties
        Config;
    end

    methods
        function obj = DelayMeasurements(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとNetworkクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % Roadクラスにおいて必要のないDelayMeasurementsを削除
                obj.get('Network').get('Roads').delete('DelayMeasurements');
                
            elseif isa(UpperClass, 'simulator.network.Road')
                % ConfigクラスとRoadクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('Road', UpperClass);
            else
                error('UppeClass is not a valid class');
            end
        end
    end
end