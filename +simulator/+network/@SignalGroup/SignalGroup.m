classdef SignalGroup < utils.class.Common
    properties
        Config;
        SignalGroups;
        SignalHeads;
        Road;
    end

    properties
        id;
        signal_heads;
        Vissim;
    end


    methods
        function obj = SignalGroup(SignalGroups, id)
            % ConfigクラスとSignalGroupsクラスを設定
            obj.Config = SignalGroups.get('Config');
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