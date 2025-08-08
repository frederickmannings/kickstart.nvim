return {
  s({ trig = ';a', snippetType = 'autosnippet', desc = 'alpha', wordTrig = false }, { t '\\alpha' }),
  s(
    { trig = 'fig', snippetType = 'snippet', dscr = 'A basic figure environment' },
    fmta(
      [[
        \begin{figure}
        \centering
        \includegraphics[width=0.9\linewidth]{<>}
        \caption{
            \textbf{<>}
            <>
            }
        \label{fig:<>}
        \end{figure}

        ]],
      { i(1, 'filename'), i(2, 'captionBold'), i(3, 'captionText'), i(4, 'figureLabel') }
    )
  ),
  s(
    { trig = 'env', snippetType = 'snippet', dscr = 'Begin and end an arbitrary environment' },
    fmta(
      [[
        \begin{<>}
            <>
        \end{<>}
        ]],
      { i(1), i(2), rep(1) }
    )
  ),
}
