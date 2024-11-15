classdef SignalHead < utils.class.Common
    properties
        Config;
        Timer;
        SignalHeads;
        Link;
        FromLink;
        ToLink;
        FromRoad;
        ToRoad;
    end

    properties
        id;
        direction;
        Vissim;
    end

    methods
        function obj = SignalHead(SignalHeads, id)
            % ConfigクラスとTimerクラスとSignalHeadsクラスを設定
            obj.Config = SignalHeads.get('Config');
            obj.Timer = SignalHeads.get('Timer');
            obj.SignalHeads = SignalHeads;

            % idを設定
            obj.id = id;

            % SignalHeadのCOMオブジェクトを設定
            obj.create('Vissim');

            % Link関連の設定
            obj.create('Links');

            % Road関連の設定
            obj.create('Roads');
        end
    end

    methods
        create(obj, property_name);
    end
end