module StringUtils
  def split_string(string, limit:)
    words = string.split
    character_count = -1
    words1, words2 = words.partition do |word|
      character_count += word.length + 1
      character_count <= limit
    end
    [words1.join(' '), (words2.join(' ')[0...limit])]
  end

  def redact(string, first: 0, last: 0, redaction: '...')
    [string.first(first), string.last(last)].join(redaction)
  end
end
