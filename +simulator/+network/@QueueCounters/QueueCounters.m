classdef QueueCounters < utils.class.Container
    properties
        Config;
        Timer;
    end
    
    methods
        function obj = QueueCounters(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとNetworkクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.Timer = UpperClass.get('Timer');
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');
                
                % Roadクラスにおいて必要のないQueueCountersを削除
                obj.get('Network').get('Roads').delete('QueueCounters');

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