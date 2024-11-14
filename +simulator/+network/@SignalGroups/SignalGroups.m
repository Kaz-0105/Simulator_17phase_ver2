classdef SignalGroups < utils.class.Container
    properties
        Config;
    end

    methods
        function obj = SignalGroups(UpperClass)
            if isa(UpperClass, 'simulator.network.SignalController')
                % ConfigクラスとSignalControllerクラスを設定
                obj.Config = UpperClass.get('Config');  
                obj.set('SignalController', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスの作成
                obj.create('Elements');

            elseif isa(UpperClass, 'simulator.network.Road')
                % ConfigクラスとRoadクラスを設定
                obj.Config = UpperClass.Config;
                obj.set('Road', UpperClass);

            elseif isa(UpperClass, 'simulator.network.Intersection')
                % ConfigクラスとIntersectionクラスを設定
                obj.Config = UpperClass.Config;
                obj.set('Intersection', UpperClass);
                
            else
                error('UpperClass must be a simulator.network.SignalController or simulator.network.Road class.');
            end
        end
    end
end