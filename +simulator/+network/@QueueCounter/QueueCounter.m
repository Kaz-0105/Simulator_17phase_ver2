classdef QueueCounter < utils.class.Common
    properties
        Config;
        QueueCounters;
        Road;
        Link;
    end

    properties
        id;
        Vissim;
    end

    methods 
        function obj = QueueCounter(QueueCounters, id)
            % ConfigクラスとQueueCountersクラスを設定
            obj.Config = QueueCounters.get('Config');
            obj.QueueCounters = QueueCounters;

            % idを設定
            obj.id = id;

            % QueueCounterのCOMオブジェクトを設定
            obj.create('Vissim');

            % Roadの設定
            obj.create('Road');
        end
    end
end