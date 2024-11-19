classdef DelayMeasurements < utils.class.Container
    properties
        Config;
        Timer;
    end

    methods
        function obj = DelayMeasurements(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとTimerクラスとNetworkクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

                % Roadクラスにおいて必要のないDelayMeasurementsを削除
                obj.get('Network').get('Roads').delete('DelayMeasurements');
                
            elseif isa(UpperClass, 'simulator.network.Road')
                % ConfigクラスとTimerクラスとRoadクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Road', UpperClass);

                % delay_tableを作成
                obj.create('delay_table');
                
            else
                error('UppeClass is not a valid class');
            end
        end
    end
end