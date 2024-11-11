function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % LinksクラスのComオブジェクトを取得
        Links = obj.Links.get('Vissim');

        % VissimのComオブジェクトを取得
        obj.Vissim = Links.ItemByKey(obj.id);
    elseif strcmp(property_name, 'type')
        % ToLinkを取得
        ToLink = obj.Vissim.ToLink;

        % ToLinkの有無によって分岐
        if isempty(ToLink)
            % typeを設定
            obj.type = 'link';
        else
            % typeを設定
            obj.type = 'connector';
        end
    elseif strcmp(property_name, 'Links')
        % ToLinksとFromLinksを初期化
        obj.set('ToLinks', simulator.network.Links(obj));
        obj.set('FromLinks', simulator.network.Links(obj));

    else
        error('Property name is invalid.');
    end
end