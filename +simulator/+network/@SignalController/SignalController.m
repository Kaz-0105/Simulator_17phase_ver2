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
        end
    end
end
