classdef SignalControllers < utils.class.Container
    properties
        Config;
        Timer;
    end

    methods
        function obj = SignalControllers(UpperClass)
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとTimerクラスとNetworkクラスを設定
                obj.Config = UpperClass.Config;
                obj.Timer = UpperClass.Timer;
                obj.set('Network', UpperClass);

                % VissimのCOMオブジェクトを設定
                obj.create('Vissim');

                % 要素クラスを作成
                obj.create('Elements');

            elseif isa(UpperClass, 'simulator.network.Intersection')
                % ConfigクラスとTimerクラスとIntersectionクラスを設定
                obj.Config = UpperClass.Config;
                obj.Timer = UpperClass.Timer;
                obj.set('Intersection', UpperClass);

            else
                error('UpperClass must be a simulator.Network or simulator.network.Intersection class.');
            end
        end 
    end
end