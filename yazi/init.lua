require("zoxide"):setup {
	-- yazi で移動したディレクトリを zoxide 側の DB にも反映し、シェルの `z` からも辿れるようにする
	update_db = true,
}
