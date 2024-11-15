classdef SignalGroup < utils.class.Common
    properties
        Config;
        Timer;
        SignalGroups;
        SignalHeads;
        Road;
    end

    properties
        id;
        order;
        direction;
        signal_heads;
        Vissim;
    end


    methods
        function obj = SignalGroup(SignalGroups, id)
            % ConfigクラスとTimerクラスとSignalGroupsクラスを設定
            obj.Config = SignalGroups.get('Config');
            obj.Timer = SignalGroups.get('Timer');
            obj.SignalGroups = SignalGroups;

            % idを設定
            obj.id = id;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % SignalHeadsクラスを作成
            obj.create('SignalHeads');

            % Roadクラスを作成
            obj.create('Road');
        end
    end
end