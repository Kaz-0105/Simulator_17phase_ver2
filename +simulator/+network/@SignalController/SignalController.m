classdef SignalController < utils.class.Common
    properties
        Config;
        SignalControllers;
        SignalGroups;
        Intersection;
    end

    properties
        id;
        Vissim;
        signal_groups;
    end

    methods
        function obj = SignalController(SignalControllers, id)
            % ConfigクラスとSignalControllersクラスを設定
            obj.Config = SignalControllers.get('Config');
            obj.SignalControllers = SignalControllers;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % SignalGroupsクラスを作成
            obj.SignalGroups = simulator.network.SignalGroups(obj);

            % Intersectionクラスを作成
            obj.create('Intersection');

            % SignalGroupクラスにorderを設定
            obj.SignalGroups.create('orders');

            % signal_groups構造体を作成
            obj.create('signal_groups');
        end
    end
end
