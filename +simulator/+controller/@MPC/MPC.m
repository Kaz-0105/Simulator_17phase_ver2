classdef MPC < utils.class.Common
    properties
        Config;
        Controller;
    end

    methods
        function obj = MPC(Controller)
            % Configクラスを設定
            obj.Config = Controller.get('Config');

            % Controllerクラスを設定
            obj.Controller = Controller;
        end
    end
end