classdef QueueCounters < utils.class.Container
    properties
        Config;
    end
    methods
        function obj = QueueCounters(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとNetworkクラスを設定
                obj.Config = UpperClass.get('Config');
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');
                
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